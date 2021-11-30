alias tmux='tmux -2'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -v'
alias ip='ip -c'
if command -v exa > /dev/null; then
    alias l='exa -lahg --icons --octal-permissions'
    alias ll='exa -lhg --icons --octal-permissions'
fi

updaterc () {
    current_dir="$PWD"
    cd ~/.dotfiles || {
        echo 'The .dotfiles folder should be at ~/.dotfiles to auto update'
        return 2
    }
    git pull
    ./install.sh
    cd "$current_dir" || return 2
    # Reload shell
    exec "$SHELL"
}
editrc () {
    [[ -d "$HOME/.dotfiles" ]] || {
        echo 'No .dotfiles folder at ~/.dotfiles'
        return 2
    }
    code ~/.dotfiles
}

command -v xclip >/dev/null && { alias setclip='xclip -selection c'; alias getclip='xclip -selection c -o'; }
command -v wl-copy >/dev/null && { alias setclip='wl-copy'; alias getclip='wl-paste'; }

alias root='sudo su -'
alias con='ssh contabo'
alias poof='poweroff'
alias pubip='curl ipinfo.io/ip'
alias apdate='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'

makeinvert () {
    pwd="$PWD"

    cd ~/Downloads || return 1
    if [[ -d kwin-effect-smart-invert ]]; then
        cd kwin-effect-smart-invert || return 2
        git pull || {
            cd "$pwd"
            return 3
        }
    else
        git clone https://github.com/natask/kwin-effect-smart-invert.git || {
            cd "$pwd"
            return 2
        }
        cd kwin-effect-smart-invert || return 3
    fi

    sed -i 's/m_allWindows(true)/m_allWindows(false)/' invert.cpp
    mkdir -p build
    cd build || return 4
    cmake .. && make && sudo make install && (kwin_x11 --replace &)

    cd "$pwd"
}
remakeinvert () {
    pwd="$PWD"

    cd ~/Downloads || return 1
    [[ -d kwin-effect-smart-invert ]] || {
        echo "Cloned repo not found at ~/Downloads/kwin-effect-smart-invert"
        cd "$pwd"
        return 2
    }
    cd kwin-effect-smart-invert || return 3
    sed -i 's/m_allWindows(true)/m_allWindows(false)/' invert.cpp
    [[ -d build ]] || {
        echo "No previous build folder present"
        cd "$pwd"
        return 4
    }
    cd build
    sudo make install && (kwin_x11 --replace &)

    cd "$pwd"
}

rewg () {
    systemctl is-active wg-quick@wg0 > /dev/null && {
        sudo systemctl restart wg-quick@wg0
        return 0
    }
    systemctl is-active wg-quick@wg1 > /dev/null && {
        sudo systemctl restart wg-quick@wg1
        return 0
    }
    echo "No known wg service is running"
    return 3
}
alias wg0='sudo systemctl stop wg-quick@wg1 && sudo systemctl start wg-quick@wg0'
alias wg1='sudo systemctl stop wg-quick@wg0 && sudo systemctl start wg-quick@wg1'

alias lelcat='bash -c "$(curl -fsSL https://raw.githubusercontent.com/RubixDev/HandyLinuxStuff/main/meow.sh)"'
cheat () { curl -s "cheat.sh/$1" | less; }
timeout () { sleep "$1"; shift; bash -c "$*"; }
colors () {
    for i in {0..255}; do
        print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
    done
}

postclip () { curl -sSL https://clip.rubixdev.de/index.php -F data="$1" -o /dev/null; }
alias fetchclip='curl -sSL https://clip.rubixdev.de/clipboard.txt'

untis () {
    user="$1"
    [[ -n "$user" ]] || {
        echo "No user specified"
        return 1
    }
    date="$2"
    [[ -n "$date" ]] || {
        echo "No date specified"
        return 1
    }

    [[ -f ~/.untisusers.json ]] || {
        echo "No '.untisusers.json' in home directory"
        return 1
    }

    username="$(jq -r ".$user.username" ~/.untisusers.json)"
    password="$(jq -r ".$user.password" ~/.untisusers.json)"
    [[ "$username" != "null" ]] && [[ "$password" != "null" ]] || {
        echo "User not found in ~/.untisusers.json"
        return 1
    }

    if [[ -n "$3" ]]; then
        filtered="true"
    else
        filtered="false"
    fi

    res="$(curl -X POST -H 'Content-Type: application/json' -d "{
        \"username\": \"$username\",
        \"password\": \"$password\",
        \"filtered\": $filtered
    }" "https://untis.rubixdev.de/timetable/$date")"
    if [[ "$(echo "$res" | jq 'has("error")')" == "true" ]]; then
        echo "$res" | jq
        return 1
    fi
    res="$(echo "$res" | jq 'to_entries | sort_by(.key) | from_entries')"

    color () {
        case "$1" in
            NORMAL            ) echo "48;5;208" ;;
            SUBSTITUTION      ) echo "48;5;134" ;;
            EXAM              ) echo "48;5;221" ;;
            CANCELLED         ) echo "48;5;246" ;;
            ROOM_SUBSTITUTION ) echo "48;5;33"  ;;
            FREE              ) echo "48;5;250" ;;
            ADDITIONAL        ) echo "48;5;34"  ;;
            *                 ) echo "48;5;169" ;;
        esac
    }

    for date in $(echo "$res" | jq -r '.[] | @base64'); do
        echo "\n----------------------------------------------------------\n"
        lessons="$(echo "$date" | base64 -d)"

        timetable=()
        for lesson in $(echo "$lessons" | jq -r 'sort_by(.lesson)[] | @base64'); do
            _jq () { echo "$lesson" | base64 -d | jq -r "$1"; }
            timetable+=(
                "$(_jq '.lesson')"
                "$(_jq '.subject.longName')"
                "$(_jq '.room.name')"
                "$(_jq '.state')"
            )
        done

        last_lesson=-1
        for (( i = 1; i <= ${#timetable[@]}; i += 4 )); do
            current_lesson="${timetable[i]}"
            for (( j = last_lesson + 1; j < current_lesson; j++ )); do
                echo -e "\t$(printf "%2s" "$j"):"
            done
            printf "\t%2s: \x1b[%sm   \x1b[0m   \x1b[1m%-32s\x1b[0m %-8s \x1b[90m%s\x1b[0m\n" "$current_lesson" "$(color "${timetable[i+3]}")" "${timetable[i+1]}" "${timetable[i+2]}" "${timetable[i+3]}"
            last_lesson="$current_lesson"
        done
        for (( i = last_lesson + 1; i <= 10; i++ )); do
            echo -e "\t$(printf "%2s" "$i"):"
        done
    done
    echo "\n----------------------------------------------------------"
}
findfont () {
    [[ -n "$1" ]] || {
        echo "Please specify a symbol to search for"
        return 1
    }
    python -c "import os

fonts = []

def add_fonts(directory):
    if not os.path.isdir(directory): return
    for root,dirs,files in os.walk(directory):
        for file in files:
            if file.endswith('.ttf'): fonts.append(os.path.join(root,file))

add_fonts('/usr/share/fonts/')
add_fonts('$HOME/.local/share/fonts/')
add_fonts('$HOME/.fonts/')


from fontTools.ttLib import TTFont

def char_in_font(unicode_char, font):
    for cmap in font['cmap'].tables:
        if cmap.isUnicode():
            if ord(unicode_char) in cmap.cmap:
                return True
    return False

def test(char):
    for fontpath in fonts:
        font = TTFont(fontpath)   # specify the path to the font in question
        if char_in_font(char, font):
            print(char + ' in ' + fontpath)

test('$1')"
}
code2pdf () {
    [[ -n "$1" ]] || {
        echo "No file specified"
        return 1
    }
    [[ -n "$2" ]] || {
        echo "No language specified"
        return 1
    }

    mkdir -p tmp
    echo -E "
\documentclass[ngerman, 12pt]{article}

\pagenumbering{gobble}
\usepackage[a4paper, margin=2cm]{geometry}
\usepackage{babel}

\usepackage[no-math]{fontspec}
\setmainfont{JetBrains Mono}
\setmonofont{JetBrains Mono NL}

\usepackage{xcolor}
\usepackage{listings}
\usepackage{tcolorbox}

\renewcommand{\lstlistingname}{Programmblock}

\tcbuselibrary{skins, breakable, listings}
\tcbset{listing engine={listings}}

\definecolor{Annotation}{HTML}{D73A49}
\definecolor{AtomGray}{HTML}{A0A1A7}

\newcommand{\boxedinputlisting}[2][]{\tcbinputlisting{
    enhanced,
    breakable,
    boxrule=0pt,
    frame hidden,
    colback=white,
    left=35pt,
    fuzzy shadow={1pt}{-1pt}{-4pt}{2pt}{AtomGray},
    arc=6pt,
    beforeafter skip balanced=14pt,
    listing only,
    listing remove caption=false,
    listing options={nolol=false, #1},
    listing file=#2,
}}

\lstdefinelanguage{Rust}{
    sensitive,
    comment=[l]{//},
    morecomment=[s]{/*}{*/},
    morecomment=[l]{///},
    morecomment=[s]{/*!}{*/},
    morecomment=[l]{//!},
    morecomment=[s][\color{Annotation}]{\#![}{]},
    morecomment=[s][\color{Annotation}]{\#[}{]},
    morestring=[b]{\\\"},
    alsoletter={!},
    % [1] reserve keywords
    % [2] traits
    % [3] primitive types
    % [4] type and value constructors
    % [5] identifier
    morekeywords={break, continue, else, for, if, in, loop, match, return, while},  % control flow keywords
    morekeywords={as, const, let, move, mut, ref, static},  % in the context of variables
    morekeywords={dyn, enum, fn, impl, Self, self, struct, trait, type, union, use, where},  % in the context of declarations
    morekeywords={crate, extern, mod, pub, super},  % in the context of modularisation
    morekeywords={unsafe},  % markers
    morekeywords={abstract, alignof, become, box, do, final, macro, offsetof, override, priv, proc, pure, sizeof, typeof, unsized, virtual, yield},  % reserved identifiers
    % grep 'pub trait [A-Za-z][A-Za-z0-9]*' -r . | sed 's/^.*pub trait \([A-Za-z][A-Za-z0-9]*\).*/\1/g' | sort -u | tr '\n' ',' | sed 's/^\(.*\),$/{\1}\n/g' | sed 's/,/, /g'
    morekeywords=[2]{Add, AddAssign, Any, AsciiExt, AsInner, AsInnerMut, AsMut, AsRawFd, AsRawHandle, AsRawSocket, AsRef, Binary, BitAnd, BitAndAssign, Bitor, BitOr, BitOrAssign, BitXor, BitXorAssign, Borrow, BorrowMut, Boxed, BoxPlace, BufRead, BuildHasher, CastInto, CharExt, Clone, CoerceUnsized, CommandExt, Copy, Debug, DecodableFloat, Default, Deref, DerefMut, DirBuilderExt, DirEntryExt, Display, Div, DivAssign, DoubleEndedIterator, DoubleEndedSearcher, Drop, EnvKey, Eq, Error, ExactSizeIterator, ExitStatusExt, Extend, FileExt, FileTypeExt, Float, Fn, FnBox, FnMut, FnOnce, Freeze, From, FromInner, FromIterator, FromRawFd, FromRawHandle, FromRawSocket, FromStr, FullOps, FusedIterator, Generator, Hash, Hasher, Index, IndexMut, InPlace, Int, Into, IntoCow, IntoInner, IntoIterator, IntoRawFd, IntoRawHandle, IntoRawSocket, IsMinusOne, IsZero, Iterator, JoinHandleExt, LargeInt, LowerExp, LowerHex, MetadataExt, Mul, MulAssign, Neg, Not, Octal, OpenOptionsExt, Ord, OsStrExt, OsStringExt, Packet, PartialEq, PartialOrd, Pattern, PermissionsExt, Place, Placer, Pointer, Product, Put, RangeArgument, RawFloat, Read, Rem, RemAssign, Seek, Shl, ShlAssign, Shr, ShrAssign, Sized, SliceConcatExt, SliceExt, SliceIndex, Stats, Step, StrExt, Sub, SubAssign, Sum, Sync, TDynBenchFn, Terminal, Termination, ToOwned, ToSocketAddrs, ToString, Try, TryFrom, TryInto, UnicodeStr, Unsize, UpperExp, UpperHex, WideInt, Write},
    morekeywords=[2]{Send},  % additional traits
    morekeywords=[3]{bool, char, f32, f64, i8, i16, i32, i64, isize, str, u8, u16, u32, u64, unit, usize, i128, u128},  % primitive types
    morekeywords=[4]{Err, false, None, Ok, Some, true},  % prelude value constructors
    % grep 'pub \(type\|struct\|enum\) [A-Za-z][A-Za-z0-9]*' -r . | sed 's/^.*pub \(type\|struct\|enum\) \([A-Za-z][A-Za-z0-9]*\).*/\2/g' | sort -u | tr '\n' ',' | sed 's/^\(.*\),$/{\1}\n/g' | sed 's/,/, /g'
    morekeywords=[3]{AccessError, Adddf3, AddI128, AddoI128, AddoU128, ADDRESS, ADDRESS64, addrinfo, ADDRINFOA, AddrParseError, Addsf3, AddU128, advice, aiocb, Alignment, AllocErr, AnonPipe, Answer, Arc, Args, ArgsInnerDebug, ArgsOs, Argument, Arguments, ArgumentV1, Ashldi3, Ashlti3, Ashrdi3, Ashrti3, AssertParamIsClone, AssertParamIsCopy, AssertParamIsEq, AssertUnwindSafe, AtomicBool, AtomicPtr, Attr, auxtype, auxv, BackPlace, BacktraceContext, Barrier, BarrierWaitResult, Bencher, BenchMode, BenchSamples, BinaryHeap, BinaryHeapPlace, blkcnt, blkcnt64, blksize, BOOL, boolean, BOOLEAN, BoolTrie, BorrowError, BorrowMutError, Bound, Box, bpf, BTreeMap, BTreeSet, Bucket, BucketState, Buf, BufReader, BufWriter, Builder, BuildHasherDefault, BY, BYTE, Bytes, CannotReallocInPlace, cc, Cell, Chain, CHAR, CharIndices, CharPredicateSearcher, Chars, CharSearcher, CharsError, CharSliceSearcher, CharTryFromError, Child, ChildPipes, ChildStderr, ChildStdin, ChildStdio, ChildStdout, Chunks, ChunksMut, ciovec, clock, clockid, Cloned, cmsgcred, cmsghdr, CodePoint, Color, ColorConfig, Command, CommandEnv, Component, Components, CONDITION, condvar, Condvar, CONSOLE, CONTEXT, Count, Cow, cpu, CRITICAL, CStr, CString, CStringArray, Cursor, Cycle, CycleIter, daddr, DebugList, DebugMap, DebugSet, DebugStruct, DebugTuple, Decimal, Decoded, DecodeUtf16, DecodeUtf16Error, DecodeUtf8, DefaultEnvKey, DefaultHasher, dev, device, Difference, Digit32, DIR, DirBuilder, dircookie, dirent, dirent64, DirEntry, Discriminant, DISPATCHER, Display, Divdf3, Divdi3, Divmoddi4, Divmodsi4, Divsf3, Divsi3, Divti3, dl, Dl, Dlmalloc, Dns, DnsAnswer, DnsQuery, dqblk, Drain, DrainFilter, Dtor, Duration, DwarfReader, DWORD, DWORDLONG, DynamicLibrary, Edge, EHAction, EHContext, Elf32, Elf64, Empty, EmptyBucket, EncodeUtf16, EncodeWide, Entry, EntryPlace, Enumerate, Env, epoll, errno, Error, ErrorKind, EscapeDebug, EscapeDefault, EscapeUnicode, event, Event, eventrwflags, eventtype, ExactChunks, ExactChunksMut, EXCEPTION, Excess, ExchangeHeapSingleton, exit, exitcode, ExitStatus, Failure, fd, fdflags, fdsflags, fdstat, ff, fflags, File, FILE, FileAttr, filedelta, FileDesc, FilePermissions, filesize, filestat, FILETIME, filetype, FileType, Filter, FilterMap, Fixdfdi, Fixdfsi, Fixdfti, Fixsfdi, Fixsfsi, Fixsfti, Fixunsdfdi, Fixunsdfsi, Fixunsdfti, Fixunssfdi, Fixunssfsi, Fixunssfti, Flag, FlatMap, Floatdidf, FLOATING, Floatsidf, Floatsisf, Floattidf, Floattisf, Floatundidf, Floatunsidf, Floatunsisf, Floatuntidf, Floatuntisf, flock, ForceResult, FormatSpec, Formatted, Formatter, Fp, FpCategory, fpos, fpos64, fpreg, fpregset, FPUControlWord, Frame, FromBytesWithNulError, FromUtf16Error, FromUtf8Error, FrontPlace, fsblkcnt, fsfilcnt, fsflags, fsid, fstore, fsword, FullBucket, FullBucketMut, FullDecoded, Fuse, GapThenFull, GeneratorState, gid, glob, glob64, GlobalDlmalloc, greg, group, GROUP, Guard, GUID, Handle, HANDLE, Handler, HashMap, HashSet, Heap, HINSTANCE, HMODULE, hostent, HRESULT, id, idtype, if, ifaddrs, IMAGEHLP, Immut, in, in6, Incoming, Infallible, Initializer, ino, ino64, inode, input, InsertResult, Inspect, Instant, int16, int32, int64, int8, integer, IntermediateBox, Internal, Intersection, intmax, IntoInnerError, IntoIter, IntoStringError, intptr, InvalidSequence, iovec, ip, IpAddr, ipc, Ipv4Addr, ipv6, Ipv6Addr, Ipv6MulticastScope, Iter, IterMut, itimerspec, itimerval, jail, JoinHandle, JoinPathsError, KDHELP64, kevent, kevent64, key, Key, Keys, KV, l4, LARGE, lastlog, launchpad, Layout, Lazy, lconv, Leaf, LeafOrInternal, Lines, LinesAny, LineWriter, linger, linkcount, LinkedList, load, locale, LocalKey, LocalKeyState, Location, lock, LockResult, loff, LONG, lookup, lookupflags, LookupHost, LPBOOL, LPBY, LPBYTE, LPCSTR, LPCVOID, LPCWSTR, LPDWORD, LPFILETIME, LPHANDLE, LPOVERLAPPED, LPPROCESS, LPPROGRESS, LPSECURITY, LPSTARTUPINFO, LPSTR, LPVOID, LPWCH, LPWIN32, LPWSADATA, LPWSAPROTOCOL, LPWSTR, Lshrdi3, Lshrti3, lwpid, M128A, mach, major, Map, mcontext, Metadata, Metric, MetricMap, mflags, minor, mmsghdr, Moddi3, mode, Modsi3, Modti3, MonitorMsg, MOUNT, mprot, mq, mqd, msflags, msghdr, msginfo, msglen, msgqnum, msqid, Muldf3, Mulodi4, Mulosi4, Muloti4, Mulsf3, Multi3, Mut, Mutex, MutexGuard, MyCollection, n16, NamePadding, NativeLibBoilerplate, nfds, nl, nlink, NodeRef, NoneError, NonNull, NonZero, nthreads, NulError, OccupiedEntry, off, off64, oflags, Once, OnceState, OpenOptions, Option, Options, OptRes, Ordering, OsStr, OsString, Output, OVERLAPPED, Owned, Packet, PanicInfo, Param, ParseBoolError, ParseCharError, ParseError, ParseFloatError, ParseIntError, ParseResult, Part, passwd, Path, PathBuf, PCONDITION, PCONSOLE, Peekable, PeekMut, Permissions, PhantomData, pid, Pipes, PlaceBack, PlaceFront, PLARGE, PoisonError, pollfd, PopResult, port, Position, Powidf2, Powisf2, Prefix, PrefixComponent, PrintFormat, proc, Process, PROCESS, processentry, protoent, PSRWLOCK, pthread, ptr, ptrdiff, PVECTORED, Queue, radvisory, RandomState, Range, RangeFrom, RangeFull, RangeInclusive, RangeMut, RangeTo, RangeToInclusive, RawBucket, RawFd, RawHandle, RawPthread, RawSocket, RawTable, RawVec, Rc, ReadDir, Receiver, recv, RecvError, RecvTimeoutError, ReentrantMutex, ReentrantMutexGuard, Ref, RefCell, RefMut, REPARSE, Repeat, Result, Rev, Reverse, riflags, rights, rlim, rlim64, rlimit, rlimit64, roflags, Root, RSplit, RSplitMut, RSplitN, RSplitNMut, RUNTIME, rusage, RwLock, RWLock, RwLockReadGuard, RwLockWriteGuard, sa, SafeHash, Scan, sched, scope, sdflags, SearchResult, SearchStep, SECURITY, SeekFrom, segment, Select, SelectionResult, sem, sembuf, send, Sender, SendError, servent, sf, Shared, shmatt, shmid, ShortReader, ShouldPanic, Shutdown, siflags, sigaction, SigAction, sigevent, sighandler, siginfo, Sign, signal, signalfd, SignalToken, sigset, sigval, Sink, SipHasher, SipHasher13, SipHasher24, size, SIZE, Skip, SkipWhile, Slice, SmallBoolTrie, sockaddr, SOCKADDR, sockcred, Socket, SOCKET, SocketAddr, SocketAddrV4, SocketAddrV6, socklen, speed, Splice, Split, SplitMut, SplitN, SplitNMut, SplitPaths, SplitWhitespace, spwd, SRWLOCK, ssize, stack, STACKFRAME64, StartResult, STARTUPINFO, stat, Stat, stat64, statfs, statfs64, StaticKey, statvfs, StatVfs, statvfs64, Stderr, StderrLock, StderrTerminal, Stdin, StdinLock, Stdio, StdioPipes, Stdout, StdoutLock, StdoutTerminal, StepBy, String, StripPrefixError, StrSearcher, subclockflags, Subdf3, SubI128, SuboI128, SuboU128, subrwflags, subscription, Subsf3, SubU128, Summary, suseconds, SYMBOL, SYMBOLIC, SymmetricDifference, SyncSender, sysinfo, System, SystemTime, SystemTimeError, Take, TakeWhile, tcb, tcflag, TcpListener, TcpStream, TempDir, TermInfo, TerminfoTerminal, termios, termios2, TestDesc, TestDescAndFn, TestEvent, TestFn, TestName, TestOpts, TestResult, Thread, threadattr, threadentry, ThreadId, tid, time, time64, timespec, TimeSpec, timestamp, timeval, timeval32, timezone, tm, tms, ToLowercase, ToUppercase, TraitObject, TryFromIntError, TryFromSliceError, TryIter, TryLockError, TryLockResult, TryRecvError, TrySendError, TypeId, U64x2, ucontext, ucred, Udivdi3, Udivmoddi4, Udivmodsi4, Udivmodti4, Udivsi3, Udivti3, UdpSocket, uid, UINT, uint16, uint32, uint64, uint8, uintmax, uintptr, ulflags, ULONG, ULONGLONG, Umoddi3, Umodsi3, Umodti3, UnicodeVersion, Union, Unique, UnixDatagram, UnixListener, UnixStream, Unpacked, UnsafeCell, UNWIND, UpgradeResult, useconds, user, userdata, USHORT, Utf16Encoder, Utf8Error, Utf8Lossy, Utf8LossyChunk, Utf8LossyChunksIter, utimbuf, utmp, utmpx, utsname, uuid, VacantEntry, Values, ValuesMut, VarError, Variables, Vars, VarsOs, Vec, VecDeque, vm, Void, WaitTimeoutResult, WaitToken, wchar, WCHAR, Weak, whence, WIN32, WinConsole, Windows, WindowsEnvKey, winsize, WORD, Wrapping, wrlen, WSADATA, WSAPROTOCOL, WSAPROTOCOLCHAIN, Wtf8, Wtf8Buf, Wtf8CodePoints, xsw, xucred, Zip, zx},
    morekeywords=[5]{assert!, assert_eq!, assert_ne!, cfg!, column!, compile_error!, concat!, concat_idents!, debug_assert!, debug_assert_eq!, debug_assert_ne!, env!, eprint!, eprintln!, file!, format!, format_args!, include!, include_bytes!, include_str!, line!, module_path!, option_env!, panic!, print!, println!, select!, stringify!, thread_local!, try!, unimplemented!, unreachable!, vec!, write!, writeln!},  % prelude macros
}

\lstdefinestyle{AtomLight}{
    basicstyle=\ttfamily,
    backgroundcolor=\color{white},
    identifierstyle=\color[HTML]{0550AE},
    commentstyle=\itshape\color{AtomGray},
    stringstyle=\color[HTML]{50A14F},
    keywordstyle=\color[HTML]{D73A49},     % rust: reserved keywords
    keywordstyle=[2]\color[HTML]{6F42C1},  % rust: traits
    keywordstyle=[3]\color[HTML]{6F42C1},  % rust: primitive types
    keywordstyle=[4]\color[HTML]{986801},  % rust: type and value constructors
    keywordstyle=[5]\color[HTML]{6F42C1},  % rust: macros
    tabsize=4,
    numbers=left,
    numberfirstline=true,
    numberstyle=\footnotesize\ttfamily\color{AtomGray},
    numbersep=10pt,
    belowcaptionskip=10pt,
    breaklines=true,
    breakindent=0pt,
    frame=l,
    framerule=1pt,
    rulecolor=\color{AtomGray},
    columns=fullflexible,
}

\begin{document}
    \boxedinputlisting[style=AtomLight, language=$2, title=$1]{$1}
\end{document}
    " > tmp/tmp.tex
    xelatex --output-directory tmp tmp/tmp.tex
    xelatex --output-directory tmp tmp/tmp.tex
    mv tmp/tmp.pdf ./"$(echo "$1" | grep -o '.*\.')"pdf
    rm -rf tmp
}

alias sr='screen -r'
alias sls='screen -ls'
